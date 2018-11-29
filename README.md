# Simplified Event Pattern

A pattern that shows the separation of concerns between a view (controller), orchestrator, state, services, and view states.

Each layer described above is necessary only in certain contexts. For instance,
1. a view controller may not need an orchestrator if it is only displaying static content
2. an orchestrator may not need to have state if the service manages the state
3. an orchestrator may not need a view state factory if there is no conditional logic to create a view state, etc.

This project illustrates how each component fits together. However, depending on the context, not every component may be necessary.

## Overview

The dependency graph for each component is as follows:

```
    +-----------+
    |  Service  |
    +-----------+
          ^
    +----------------+   +---------+   +--------------------+
    |  Orchestrator  | > |  State  | > |  ViewStateFactory  |
    +----------------+   +---------+   +--------------------+
            ^                                    |
    +------------------+                         |
    |  ViewController  |  <----------------------+
    +------------------+
```

Notes:
- An `Orchestrator` (currently the `CommandAndControl` class in this project) is a dependency of the `ViewController`
- A `State` (BusinessLogic protocol), `ViewStateFactory`, and `Service`s are dependencies for the `Orchestrator`.

## Example

A user taps the "Add to Bag" button in the view controller. The view controller would:
1. emit a `addToBag` signal to the orchestrator (the `CommandAndControl` class)
2. the orchestrator makes a service call to add the item to the bag
3. once a response is returned it then updates the state with the current quantity in the bag
4. generates a new view state using the view state factory
5. sends the new view state to the view controller

## Reasoning

Almost every event library/pattern requires the consumer to follow a rigid set of rules for every context. One could argue that it provides consistency to the app. However, it also introduces unnecessary complexity. This pattern provides a way to use only the components desired for a given context. It also doesn't say how signals are sent to/from each of the layers/components. You could use Rx, delegation, Futures, etc. The most important thing this example tries to illustrate is defining the separation of concerns.

Another important aspect of this design is that each component can be tested in isolation. Please review each of the specs to get an idea of how each component can be tested.

## Other Notes

This design applies liberal use of single responsibility and encapsulation.

This idea could be taken further by using dependency inversion where consumers would define the interface it requires in order to perform its job. For example, the `ViewController` could create a `protocol` called `ViewControllerProvider` which defines the signals it wishes to send, how it recieves responses from the provider, as well as how it wishes the data to be shaped. The beneftis of this are:

1. each individual component can be worked on in-tandem. Where the UI could be worked on idependently from the `Orchestrator`, the `Service`, or even the `State` (`BusinessLogic` protocol).
2. pushes complexity of data shaping, etc. as close to the service layer as possible, as each successive layer in the stack requires a given provider to give it the data in the shape it requires.
3. helps define the responsibility of a component further up the stream. When you develop a service without knowing what the consumer wants, often times your assumptions as to what they want could be wrong -- which may require rework at integration time.
