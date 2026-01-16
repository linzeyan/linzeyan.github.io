import torch
from PIL import Image
from train import Net
import numpy as np
import utils
from torchvision.transforms import functional


class Predictor(object):
    def __init__(self, model_path, gpu=True):
        self.net = Net(gpu)
        self.net.load(model_path)

    def identify(self, im_path):
        im = Image.open(im_path)

        # to tensor
        np_img = np.asarray(im)
        image = np_img.transpose((2, 0, 1))  # H x W x C  -->  C x H x W
        im = torch.from_numpy(image).float()

        # normalize
        im = functional.normalize(im, [127.5, 127.5, 127.5], [128, 128, 128])
        if self.net.device != 'cpu':  # to cpu
            im = im.to(utils.DEVICE)

        with torch.no_grad():
            xb = im.unsqueeze(0)
            out = self.net(xb).squeeze(0).view(utils.CAPTCHA, len(utils.CHARS))
            _, predicted = torch.max(out, 1)
            ans_list = [utils.CHARS[i] for i in predicted.tolist()]
        ans = ''
        for i in ans_list:
            ans += i
        return ans

if __name__ == '__main__':
    man = Predictor('pretrained')
    path = input('Enter image path, empty to exist: ')
    while path != '':
        print(man.identify(path))
        path = input('Enter image path, empty to exist: ')
