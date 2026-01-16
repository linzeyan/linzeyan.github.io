import os
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
import numpy as np
from torchviz import make_dot
import utils
from timeit import default_timer as timer


class Net(nn.Module):
    def __init__(self, gpu=False):
        super(Net, self).__init__()
        # size: 3 * 60 * 200
        self.conv1 = nn.Conv2d(3, 18, 5)  # 18 * 56(60-5+1) * 196(200-5+1)
        self.pool1 = nn.MaxPool2d(2)  # 18 * 28((56-2)/2+1) * 98((196-2)/2+1)
        self.conv2 = nn.Conv2d(18, 48, 5)  # 48 * 24(28-5+1) * 94(98-5+1)
        self.pool2 = nn.MaxPool2d(2)  # 48 * 12((24-2)/2+1) * 47((94-2)/2+1)
        self.length = utils.IMG_LENGTH
        self.width = utils.IMG_WIDTH
        self.chars = len(utils.CHARS)
        self.numbers = utils.CAPTCHA
        # flatten here
        self.drop = nn.Dropout(0.5)
        self.fc1 = nn.Linear(48 * 12 * 47, 360)
        self.fc2 = nn.Linear(360, self.chars * self.numbers) # CHARS=> 33

        if gpu:
            self.to(utils.DEVICE)
            if str(utils.DEVICE) == 'cpu':
                self.device = 'cpu'
            else:
                self.device = torch.cuda.get_device_name(0)

    def forward(self, x):
        x = F.relu(self.conv1(x))
        x = self.pool1(x)
        x = F.relu(self.conv2(x))
        x = self.pool2(x)
        x = x.view(-1, 48 * 12 * 47)  # flatten here
        x = self.drop(x)
        x = F.relu(self.fc1(x))
        x = self.fc2(x).view(-1, self.numbers, self.chars)
        x = F.softmax(x, dim=2)
        x = x.view(-1, self.chars * self.numbers)
        return x

    def save(self, name, folder=utils.MODEL_FOLDER):
        if not os.path.exists(folder):
            os.makedirs(folder)
        path = os.path.join(folder, name)
        torch.save(self.state_dict(), path)

    def load(self, name, folder=utils.MODEL_FOLDER):
        path = os.path.join(folder, name)
        map_location = 'cpu' if self.device == 'cpu' else 'gpu'
        static_dict = torch.load(path, map_location)
        self.load_state_dict(static_dict)
        self.eval()

    def graph(self):
        x = torch.rand(1, 3, self.length, self.width)
        y = self(x)
        return make_dot(y, params=dict(self.named_parameters()))


def loss_batch(model, loss_func, data, opt=None):
    xb, yb = data['image'], data['label']
    batch_size = len(xb)
    out = model(xb)
    loss = loss_func(out, yb)

    single_correct, whole_correct = 0, 0
    if opt is not None:
        opt.zero_grad()
        loss.backward()
        opt.step()
    else:  # calc accuracy
        yb = yb.view(-1, utils.CAPTCHA, len(utils.CHARS))
        out_matrix = out.view(-1, utils.CAPTCHA, len(utils.CHARS))
        _, ans = torch.max(yb, 2)
        _, predicted = torch.max(out_matrix, 2)
        compare = (predicted == ans)
        single_correct = compare.sum().item()
        for i in range(batch_size):
            if compare[i].sum().item() == 4:
                whole_correct += 1
        del out_matrix
    loss_item = loss.item()
    del out
    del loss
    return loss_item, single_correct, whole_correct, batch_size


def fit(epochs, model, loss_func, opt, train_dl, valid_dl, verbose=None):
    max_acc = 0
    patience_limit = 2
    patience = 0
    for epoch in range(epochs):
        patience += 1
        running_loss = 0.0
        total_nums = 0
        model.train()  # train mode
        for i, data in enumerate(train_dl):
            loss, _, _, s = loss_batch(model, loss_func, data, opt)
            if isinstance(verbose, int):
                running_loss += loss * s
                total_nums += s
                if i % verbose == verbose - 1:
                    ave_loss = running_loss / total_nums
                    print('[Epoch {}][Batch {}] got training loss: {:.6f}'
                          .format(epoch + 1, i + 1, ave_loss))
                    total_nums = 0
                    running_loss = 0.0

        model.eval()  # validate mode, working for drop out layer.
        with torch.no_grad():
            losses, single, whole, batch_size = zip(
                *[loss_batch(model, loss_func, data) for data in valid_dl]
            )
        total_size = np.sum(batch_size)
        val_loss = np.sum(np.multiply(losses, batch_size)) / total_size
        single_rate = 100 * np.sum(single) / (total_size * 4)
        whole_rate = 100 * np.sum(whole) / total_size
        if single_rate > max_acc:
            patience = 0
            max_acc = single_rate
            model.save('pretrained')

        print('After epoch {}: \n'
              '\tLoss: {:.6f}\n'
              '\tSingle Acc: {:.2f}%\n'
              '\tWhole Acc: {:.2f}%'
              .format(epoch + 1, val_loss, single_rate, whole_rate))
        if patience > patience_limit:
            print('Early stop at epoch {}'.format(epoch + 1))
            break


def train(use_gpu=True):
    # elements = batch_size * len(utils.CHARS) * utils.CAPTHA
    train_dl, valid_dl = utils.load_data(batch_size=40, split_rate=0.2, gpu=use_gpu)
    model = Net(use_gpu)
    opt = optim.Adadelta(model.parameters())
    criterion = nn.BCELoss()  # loss function
    start = timer()
    fit(30, model, criterion, opt, train_dl, valid_dl, 100000)
    end = timer()
    t = utils.human_time(start, end)
    print('Total training time using {}: {}'.format(model.device, t))


if __name__ == '__main__':
    train(True)
