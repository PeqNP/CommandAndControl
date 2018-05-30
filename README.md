# Business Logic

This project is used to illustrate separation of concerns from UI (view controllers) -> Command & Control (Manages signals sent to state machine and maps state to respective view states) -> State Machine (Business Logic) -> Services (Query data source and map to Business Objects/Models such as `Product`s, `SKU`s, etc.)

The examples in this project show synchronous and asynchronous events can be handled. Some types of view events may require data from a remote service on as-needed basis. While other events simply work on cached data loaded at the time the page is displayed to the user.

## TODO

- Asynchronous event
- Add `loading` event to state. This way C&C events can be fired to view controller (`.showLoadingIndicator`, `.hideLoadingIndicator`) or it can simply be part of the view state passed to the view controller. The latter would require logic in the view controller (which we may not want). I haven't figured out what a good approach is.
- Tests for all layers of the system (view controller / C&C / state machine / etc.).
