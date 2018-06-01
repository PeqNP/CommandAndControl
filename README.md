# Business Logic

This project is used to illustrates how separation of concerns can be achieved using this CommandAndControl pattern. The flow of data is very similar to Redux where events are received by the UI (view controllers) -> Command & Control (Receives signals, interacts with state machine, and maps state to respective view states) -> State Machine (business logic) -> Services (query remote data source, map to Business Objects/Models.

The examples in this project show how synchronous and asynchronous events can be handled. Some types of view events may require data from a remote service on an as-needed basis. While other events simply work on cached data loaded at the time the page is displayed to the user.

## TODO

- Tests for all layers of the system (view controller / C&C / state machine / etc.).
