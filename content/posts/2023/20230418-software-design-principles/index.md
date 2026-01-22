---
title: "Some Software Design Principles"
date: 2023-04-18T13:58:38+08:00
menu:
  sidebar:
    name: "Some Software Design Principles"
    identifier: software-design-principles
    weight: 10
tags: ["Links", "software", "design", "principle"]
categories: ["Links", "software", "design", "principle"]
---

- [Some Software Design Principles](https://coolshell.cn/articles/4535.html)

### 1. Don't Repeat Yourself (DRY)

### 2. Keep It Simple, Stupid (KISS)

Making something complex is easy, but making something complex simple is difficult.

### 3. Program to an interface, not an implementation

1. Prefer composition over inheritance
2. Dependency inversion principle

### 4. Command-Query Separation (CQS)

- Query: when a method returns a value to answer a question
- Command: when a method changes the state of an object

### 5. You Ain't Gonna Need It (YAGNI)

Only design and implement what is necessary. Avoid overengineering. Implement what you need now; add more when needed later.

### 6. Law of Demeter

> Principle of Least Knowledge
> Don't talk to strangers

> If you want your dog to run, do you talk to the dog or to its four legs?
> If you buy something in a store, do you hand money to the cashier, or give them your wallet and let them take it?

For a method M on object O, M should only access methods on the following objects:

1. Object O
2. Component objects directly related to O
3. Objects created or instantiated by method M
4. Objects passed as parameters to method M

### 7. S.O.L.I.D principles of object-oriented design

#### Single Responsibility Principle (SRP)

A class should do one thing and do it well, and it should have only one reason to change.

- Unix/Linux is a perfect example. Each program does one thing.
- Windows is the opposite example. Almost all programs are intertwined and tightly coupled.

#### Open/Closed Principle (OCP)

Modules should be open for extension but closed for modification.

- Open for extension means you can extend existing code to meet new requirements or changes.
- Closed for modification means once a class is designed, it should work without modifying its code.

#### Liskov substitution principle (LSP)

"Subtypes must be substitutable for their base types". In other words, subclasses must be able to replace their base classes. Subclasses should be usable anywhere their base classes are used, and the code should still work correctly after substitution.

#### Interface Segregation Principle (ISP)

Interfaces should be split by functionality. It is better to use multiple specialized interfaces than a single general-purpose interface.

#### Dependency Inversion Principle (DIP)

High-level modules should not depend on low-level module implementations, but on abstractions.

- A wall switch should not depend on the specific implementation of a light switch; it should depend on an abstract switch interface. This allows the switch to control other devices when the program evolves.
- A browser does not depend on the web server behind it; it only depends on the HTTP protocol.

### 8. Common Closure Principle (CCP)

All classes in a package should be closed to the same type of change. A change that affects a package affects all its classes. In short: classes that change together should be packaged together. If you must change the application code, you want the changes to be limited to a single package rather than spread across many packages.

### 9. Common Reuse Principle (CRP)

All classes in a package are reused together. If you reuse one class, you reuse them all. Conversely, classes that are not reused together should not be packaged together.

### 10. Hollywood Principle

don't call us, we'll call you.

This means the container controls relationships between programs, rather than programs directly controlling each other. This is the idea of inversion of control:

1. Do not create objects directly; describe how to create them.
2. Objects and services are not directly linked in code; the container wires them together.

Control moves from application code to the external container; this transfer of control is the inversion.

### 11. High Cohesion & Low/Loose coupling

- Cohesion: the degree to which elements in a module belong together
- Coupling: the degree of interdependence between modules in a software structure

### 12. Convention over Configuration (CoC)

Use commonly accepted configuration and information as the default rules internally.

### 13. Separation of Concerns (SoC)

This principle means separating a problem into distinct concerns. If a problem can be decomposed into independent, smaller problems, it becomes easier to solve.

### 14. Design by Contract (DbC)

### 15. Acyclic Dependencies Principle (ADP)
