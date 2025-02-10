## 0.2.0
- fix: Using the "Delete" button on Windows will cause the cursor to jump to a position at index 1 when deleting from the start.
- feat: Introduced `isEmptyAllowed` flag for `AmountInputFormatter` constructor and as a parameter for `NumberFormatter`. It determines whether the TextField content can be empty or a formatted zero.


## 0.1.0
* ### Initial package release.
* Added  to use with `TextField` widget.
* Added `NumberFormatter` to use for raw number parsing and formatting.
* Added `TextEditingController` extension with methods `setAndFormatText` and `syncWithFormatter`.
