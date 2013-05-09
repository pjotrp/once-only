Feature: Execute command line

  Once-only asserts a command in only run once, based on the inputs on the 
  command line.

  Scenario: Test first run and skip execute of second run
    Given a command '/bin/cat LICENSE.txt'
    When I run the command the first time
    Then once-only should create a checksum
    When I run the command the second time with the same inputs
    Then once-only should not recreate the checksum and skip the run

  Scenario: Run gives an error
    Given a command '/bin/cat LICENSE.txt.none'
    When I run the command the first time
    Then once-only should pass back an error

  Scenario: Executable does not exist
    Given a command '/binxx/cat LICENSE.txt'
    When I run the non-existing command
    Then once-only should pass back a wrong command error
