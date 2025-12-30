---
title: "一些软件设计的原则"
date: 2023-04-18T13:58:38+08:00
menu:
  sidebar:
    name: "一些软件设计的原则"
    identifier: software-design-principles
    weight: 10
tags: ["URL", "software", "design", "principle"]
categories: ["URL", "software", "design", "principle"]
---

- [一些软件设计的原则](https://coolshell.cn/articles/4535.html)

### 1. Don't Repeat Yourself (DRY)

### 2. Keep It Simple, Stupid (KISS)

把一个事情搞复杂是一件简单的事，但要把一个复杂的事变简单，这是一件复杂的事。

### 3. Program to an interface, not an implementation

1. 喜欢组合而不是继承
2. 依赖倒置原则

### 4. Command-Query Separation (CQS) - 命令-查询分离原则

- 查询：当一个方法返回一个值来回应一个问题的时候，它就具有查询的性质；
- 命令：当一个方法要改变对象的状态的时候，它就具有命令的性质；

### 5. You Ain't Gonna Need It (YAGNI)

只考虑和设计必须的功能，避免过度设计。只实现目前需要的功能，在以后您需要更多功能时，可以再进行添加。

### 6. Law of Demeter - 迪米特法则

> 最少知识原则（Principle of Least Knowledge）
> 不要和陌生人说话

> 如果你想让你的狗跑的话，你会对狗狗说还是对四条狗腿说？
> 如果你去店里买东西，你会把钱交给店员，还是会把钱包交给店员让他自己拿？

对于对象 O 中一个方法 M ，M 应该只能够访问以下对象中的方法：

1. 对象 O；
2. 与 O 直接相关的 Component Object；
3. 由方法 M 创建或者实例化的对象；
4. 作为方法 M 的参数的对象。

### 7. 面向对象的 S.O.L.I.D 原则

#### Single Responsibility Principle (SRP) - 职责单一原则

一个类，只做一件事，并把这件事做好，其只有一个引起它变化的原因

- Unix/Linux 是这一原则的完美体现者。各个程序都独立负责一个单一的事。
- Windows 是这一原则的反面示例。几乎所有的程序都交织耦合在一起。

#### Open/Closed Principle (OCP) - 开闭原则

模块是可扩展的，而不可修改的。也就是说，对扩展是开放的，而对修改是封闭的。

- 对扩展开放，意味着有新的需求或变化时，可以对现有代码进行扩展，以适应新的情况。
- 对修改封闭，意味着类一旦设计完成，就可以独立完成其工作，而不要对类进行任何修改。

#### Liskov substitution principle (LSP) - 里氏代换原则

"Subtypes must be substitutable for their base types"。也就是，子类必须能够替换成它们的基类。即：子类应该可以替换任何基类能够出现的地方，并且经过替换以后，代码还能正常工作。

#### Interface Segregation Principle (ISP) - 接口隔离原则

接口隔离原则意思是把功能实现在接口中，而不是类中，使用多个专门的接口比使用单一的总接口要好。

#### Dependency Inversion Principle (DIP) - 依赖倒置原则

高层模块不应该依赖于低层模块的实现，而是依赖于高层抽象。

- 墙面的开关不应该依赖于电灯的开关实现，而是应该依赖于一个抽象的开关的标准接口，这样，当我们扩展程序的时候，我们的开关同样可以控制其它不同的灯，甚至不同的电器。
- 浏览器并不依赖于后面的 web 服务器，其只依赖于 HTTP 协议。

### 8. Common Closure Principle（CCP）- 共同封闭原则

一个包中所有的类应该对同一种类型的变化关闭。一个变化影响一个包，便影响了包中所有的类。一个更简短的说法是：一起修改的类，应该组合在一起（同一个包里）。如果必须修改应用程序里的代码，我们希望所有的修改都发生在一个包里（修改关闭），而不是遍布在很多包里。

### 9. Common Reuse Principle (CRP) - 共同重用原则

包的所有类被一起重用。如果你重用了其中的一个类，就重用全部。换个说法是，没有被一起重用的类不应该被组合在一起。

### 10. Hollywood Principle - 好莱坞原则

don't call us, we'll call you.

就是由容器控制程序之间的关系，而非传统实现中，由程序代码直接操控。这也就是所谓"控制反转"的概念所在：

1. 不创建对象，而是描述创建对象的方式。
2. 在代码中，对象与服务没有直接联系，而是容器负责将这些联系在一起。

控制权由应用代码中转到了外部容器，控制权的转移，是所谓反转。

### 11. High Cohesion & Low/Loose coupling - 高内聚， 低耦合

- 内聚：一个模块内各个元素彼此结合的紧密程度
- 耦合：一个软件结构内不同模块之间互连程度的度量

### 12. Convention over Configuration（CoC）- 惯例优于配置原则

将一些公认的配置方式和信息作为内部缺省的规则来使用。

### 13. Separation of Concerns (SoC) - 关注点分离

这个原则，就是在软件开发中，通过各种手段，将问题的各个关注点分开。如果一个问题能分解为独立且较小的问题，就是相对较易解决的。

### 14. Design by Contract (DbC) - 契约式设计

### 15. Acyclic Dependencies Principle (ADP) - 无环依赖原则
