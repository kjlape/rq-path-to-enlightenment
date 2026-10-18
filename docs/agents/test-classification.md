Test Types and When to Keep Them
Unit Tests
Tests of a small, isolated unit (often with mocks/doubles).
	•	During development: Keep and use heavily. They give fast feedback, drive design via TDD (red-green-refactor), and clarify boundaries.
	•	After merge / long-term: Keep only when the unit is stable, pure, and non-trivial (complex domain logic, algorithms, calculations, state machines, validation rules). Delete or rewrite the rest. Heavily mocked or structure-coupled unit tests become a maintenance burden that slows refactoring without protecting real behavior.
Integration Tests
Tests that exercise multiple real components collaborating (e.g., controller + model + database, or service + real collaborators at a meaningful boundary).
	•	During development: Useful, but secondary to unit tests while shaping design.
	•	After merge / long-term: Primary tests to keep. They verify actual collaboration and catch most real regressions while remaining relatively stable under internal refactoring. Prefer these over isolated unit tests for application code.
Acceptance / End-to-End / System Tests
Tests that drive the system through a user- or external-facing interface (UI, HTTP API, full request cycle) and assert on observable outcomes.
	•	During development: Optional for confidence; often written or expanded once the feature shape is clear.
	•	After merge / long-term: Keep a small, high-value set covering critical user journeys and key business outcomes. Avoid large suites of them—they are slow, brittle, and expensive to maintain. A few smoke tests plus solid integration tests usually give better ROI.
Characterization / Golden Master Tests
Tests that lock down current behavior of existing code (often legacy) without asserting ideal design.
	•	During development: Useful when modifying or understanding untrusted code.
	•	After merge / long-term: Keep temporarily while the area is being actively changed or replaced. Delete once the code is well-understood and covered by better behavioral tests.
Static Analysis / Type Checking / Linting
Not runtime tests, but automated checks that run continuously.
	•	Always keep. Cheap, fast, and catch whole classes of errors before any tests run.

Practical rule of thumb If a test breaks when you refactor internal structure but external behavior is unchanged, it is usually protecting the wrong thing—delete or raise it to a higher level. Prioritize tests that survive refactoring while still failing when real behavior breaks.

