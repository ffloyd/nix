#
# THE MOST IMPORTANT CODING RULES
#

NEVER NEVER NEVER NEVER EVER DO `git add`, `git push`, `git stage`, `git unstage` or similar mutating git operations. Only do `git commit` when EXPLICITLY INSTRUCTED TO DO SO. Read-only operations like `git status`, `git diff`, `git log` are allowed.

# Common Coding Rules

__Do "why-comments", never do "what-comments".__ When write comments in code focus on answering "why is it here?" instead of explaining "what is it here?".

__Never do handling of unexpected situations.__ Always think is some situation expected or not. If situation is unexpected - prefer to use exceptions (raise, throw, etc). If situation is expected - return outcome as a result. _If you unsure what's expected and what's not - ask user._

__Always document responsibilities and expectations.__ Documentation for functions (and similar concepts) should focus on responsibilities and expectations. Do not merely explain "what function does". Explain "what is function responsible for and what are the function's expectations".
    - For example, function `make_frienship(user1, user2)` is responsible for making friendship between two users. It expects that both users are valid.
    - "expectations" are things that function assumes to be true.
        - "Expeceted to be called when user needs A" - is NOT an expecetation.
        - "Expects B to be in place" - is an expectation.
        - If expectations are not met - function raises exception or similar failure.
    - Follow this format:
        - first paragraph: responsibilities. For example: "Creates a friendship relationship between two users."
        - second paragraph (optional): expectations if they present. For example: "Both users should be valid."
        - third paragraph (optional): important details. For example: "If users are already friends, does nothing."

__Keep documentation actual.__ Always update documentation after code changes. Documentation is important, do your best to keep it actual.

__Keep errors helpful.__ ALWAYS think about how helpful error is when you define an error. Especially when designing error messages, log messages, error payloads, validation errors etc. Imagine an engineer or user seeing this error. Will it be enough to understand what is wrong and find related defects?

# Common Coding Rules for Writing Tests

__Use simplest tests when expected output is an exception.__ When writing tests - do the simplest check that exception happens when unexpected situation happens. Do not check what's inside exception. At most check exception type if a custom exception type were introduced.

__Split test sections for better readability.__ When write tests make visual distiction (empty line or similar) between test setup, action that is subject of the test and validation of outcome.

__Use "partial match" to test string with human-readable text.__ In tests that check against error messages, log outputs or other strings with content in human language - never do string comparison. Instead, check only that string contains important parts: field names, IDs, error code, etc.

# Elixir Coding Rules

__Be explicit about expectations of non-local function results.__ Always wrap calls to non-local functions in `case`, don't use default branch - all expected results should be explicitly matched. When only one expected result - use offensive match like `{:ok, result} = ...`.

__Let it fail!__ Do offensive Elixir matches and raise exceptions by default. I'll instruct explicitly when I want to process an incoming error tuple.

__Always fail on unexpected situations.__ Use offensive matches (`{:ok, result} = ...`) when the error case is truly unexpected and should crash. Use `case` statements only when you need to handle multiple expected outcomes.
