# Code principles — Reference for the skill-executor

> Universal software engineering principles. Not specific to any language.
> The executor applies these principles when WRITING code. The auditor verifies stack-specific rules.

## KISS — Simplicity first

Code should be as simple as possible. If there is a direct way to solve something, use it. Abstractions, patterns, and indirections only enter when the problem demands it.

## YAGNI — Don't build what you don't need now

Don't implement classes, methods, or parameters thinking about "future possibilities." Implement strictly what the current requirement demands. Speculative code is technical debt from birth.

## SoC — Separation of Concerns

Each layer has a defined job. Handler never queries. Repository never validates requests. Entity never accesses the database.

## Law of Demeter — Talk only to your neighbors

A method should only call: its own methods, methods of received parameters, methods of internally created objects. Never chain calls crossing layers.

## Composition over inheritance

Prefer dependency injection and composition over deep inheritance hierarchies. Inheritance only when there is a genuine "is a" relationship.

## SOLID — Single Responsibility (SRP)

A class has one and only one reason to change. If the class needs to change for two independent reasons, it's doing too much.

## SOLID — Open/Closed (OCP)

Classes should be open for extension, closed for modification. Add behavior without altering existing code.

## SOLID — Dependency Inversion (DIP)

High-level modules don't depend on low-level modules. Both depend on abstractions.
