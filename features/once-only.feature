Feature: Execute command line

  Once-only asserts a command in only run once, based on the inputs on the 
  command line.

  Scenario: Test first run
    Given a command '/bin/cat LICENSE.txt'
    When I run the command the first time
    Then once-only should create a checksum
    When I run the command the second time with the same inputs
    Then once-only should not recreate the checksum and skip the run
