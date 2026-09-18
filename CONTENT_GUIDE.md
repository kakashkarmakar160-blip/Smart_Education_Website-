# Content Guide

Each model-question JSON follows this general shape:

- id
- class
- class_name
- subject
- subject_name
- school_id
- school_name
- set_number
- title
- language
- questions[]

Question types:
1. mcq
2. fill_blank
3. true_false
4. short_answer

For a worked numerical/problem solution:
- set `"solution": {"enabled": true, "steps": [...]}`

The front-end reads these JSON files dynamically, so adding question content does not require creating a new HTML page.
