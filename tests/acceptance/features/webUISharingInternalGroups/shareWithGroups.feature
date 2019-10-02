Feature: Sharing files and folders with internal groups
  As a user
  I want to share files and folders with groups
  So that those groups can access the files and folders

  Background:
    Given these users have been created with default attributes:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And these groups have been created:
      | groupname |
      | grp1      |
    And user "user1" has been added to group "grp1"
    And user "user2" has been added to group "grp1"

  @smokeTest @yetToImplement
  Scenario Outline: share a file & folder with another internal user
    Given user "user3" has logged in using the webUI
    When the user shares folder "simple-folder" with group "grp1" as "<set-role>" using the webUI
    And the user shares file "testimage.jpg" with group "grp1" as "<set-role>" using the webUI
    Then group "grp1" should be listed as "<expected-role>" in the collaborators list for folder "simple-folder" on the webUI
    And group "grp1" should be listed as "<expected-role>" in the collaborators list for file "testimage.jpg" on the webUI
    And user "user1" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user3                |
      | share_with  | grp1                 |
      | file_target | /simple-folder (2)   |
      | item_type   | folder               |
      | permissions | <permissions-folder> |
    And user "user2" should have received a share with these details:
      | field       | value              |
      | uid_owner   | user3              |
      | share_with  | grp1               |
      | file_target | /testimage (2).jpg |
      | item_type   | file               |
      | permissions | <permissions-file> |
    And as "user1" these resources should be listed on the webUI
      | entry_name        |
      | simple-folder (2) |
      | testimage (2).jpg |
    And these resources should be listed in the folder "simple-folder (2)" on the webUI
      | lorem.txt |
    But these resources should not be listed in the folder "simple-folder (2)" on the webUI
      | entry_name        |
      | simple-folder (2) |
    #    And folder "simple-folder (2)" should be marked as shared by "User Two" on the webUI
    #    And file "testimage (2).jpg" should be marked as shared by "User Two" on the webUI
    Examples:
      | set-role    | expected-role | permissions-folder         | permissions-file |
      | Viewer      | Viewer        | read                       | read             |
      | Editor      | Editor        | read,change,create, delete | read,change      |
      | Custom Role | Viewer        | read                       | read             |

  @skip @yetToImplement
  Scenario: share a file with an internal group a member overwrites and unshares the file
    Given user "user3" has logged in using the webUI
    When the user renames file "lorem.txt" to "new-lorem.txt" using the webUI
    And the user shares file "new-lorem.txt" with group "grp1" using the webUI
    And the user re-logs in as "user1" using the webUI
    Then the content of "new-lorem.txt" should not be the same as the local "new-lorem.txt"
    # overwrite the received shared file
    When the user uploads overwriting file "new-lorem.txt" using the webUI and retries if the file is locked
    Then file "new-lorem.txt" should be listed on the webUI
    And the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
    # unshare the received shared file
    When the user unshares file "new-lorem.txt" using the webUI
    Then file "new-lorem.txt" should not be listed on the webUI
    # check that another group member can still see the file
    When the user re-logs in as "user2" using the webUI
    Then the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
    # check that the original file owner can still see the file
    When the user re-logs in as "user3" using the webUI
    Then the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"

  @skip @yetToImplement
  Scenario: share a folder with an internal group and a member uploads, overwrites and deletes files
    Given user "user3" has logged in using the webUI
    When the user renames folder "simple-folder" to "new-simple-folder" using the webUI
    And the user shares folder "new-simple-folder" with group "grp1" using the webUI
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then the content of "lorem.txt" should not be the same as the local "lorem.txt"
    # overwrite an existing file in the received share
    When the user uploads overwriting file "lorem.txt" using the webUI and retries if the file is locked
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" should be the same as the local "lorem.txt"
    # upload a new file into the received share
    When the user uploads file "new-lorem.txt" using the webUI
    Then the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
    # delete a file in the received share
    When the user deletes file "data.zip" using the webUI
    Then file "data.zip" should not be listed on the webUI
    # check that the file actions by the sharee are visible to another group member
    When the user re-logs in as "user2" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then the content of "lorem.txt" should be the same as the local "lorem.txt"
    And the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
    And file "data.zip" should not be listed on the webUI
    # check that the file actions by the sharee are visible for the share owner
    When the user re-logs in as "user3" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then the content of "lorem.txt" should be the same as the local "lorem.txt"
    And the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
    And file "data.zip" should not be listed on the webUI

  @skip @yetToImplement
  @smokeTest
  Scenario: share a folder with an internal group and a member unshares the folder
    Given user "user3" has logged in using the webUI
    When the user renames folder "simple-folder" to "new-simple-folder" using the webUI
    And the user shares folder "new-simple-folder" with group "grp1" using the webUI
    # unshare the received shared folder and check it is gone
    When the user re-logs in as "user1" using the webUI
    And the user unshares folder "new-simple-folder" using the webUI
    Then folder "new-simple-folder" should not be listed on the webUI
    # check that the folder is still visible to another group member
    When the user re-logs in as "user2" using the webUI
    Then folder "new-simple-folder" should be listed on the webUI
    When the user opens folder "new-simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" should be the same as the original "simple-folder/lorem.txt"
    # check that the folder is still visible for the share owner
    When the user re-logs in as "user3" using the webUI
    Then folder "new-simple-folder" should be listed on the webUI
    When the user opens folder "new-simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" should be the same as the original "simple-folder/lorem.txt"

  @skip @yetToImplement
  Scenario: user tries to share a file in a group which is excluded from receiving share
    Given group "system-group" has been created
    And the administrator has browsed to the admin sharing settings page
    When the administrator excludes group "system-group" from receiving shares using the webUI
    Then user "user1" should not be able to share file "lorem.txt" with group "system-group" using the sharing API

  @skip @yetToImplement
  Scenario: user tries to share a folder in a group which is excluded from receiving share
    Given group "system-group" has been created
    And the administrator has browsed to the admin sharing settings page
    When the administrator excludes group "system-group" from receiving shares using the webUI
    Then user "user1" should not be able to share folder "simple-folder" with group "system-group" using the sharing API

  @skip @yetToImplement
  Scenario: autocompletion for a group that is excluded from receiving shares
    Given group "system-group" has been created
    And the administrator has browsed to the admin sharing settings page
    When the administrator excludes group "system-group" from receiving shares using the webUI
    And the user re-logs in as "user1" using the webUI
    And the user browses to the files page
    And the user opens the share dialog for folder "simple-folder" using the webUI
    And the user types "system-group" in the share-with-field
    Then a tooltip with the text "No users or groups found for system-group" should be shown near the share-with-field on the webUI
    And the autocomplete list should not be displayed on the webUI

  Scenario: user shares the file/folder with a group and delete the share with group
    Given user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with group "grp1"
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then group "grp1" should be listed as "Editor" in the collaborators list on the webUI
    When the user deletes "grp1" as collaborator for the current file using the webUI
    Then group "grp1" should not be listed in the collaborators list on the webUI
    And file "lorem.txt" should not be listed in shared-with-others page on the webUI
    And as "user2" file "lorem (2).txt" should not exist

  Scenario: user shares the file/folder with multiple internal users and delete the share with one user
    Given group "grp2" has been created
    And user "user3" has been added to group "grp2"
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with group "grp1"
    And user "user1" has shared file "lorem.txt" with group "grp2"
    When the user opens the share dialog for file "lorem.txt" using the webUI
    Then group "grp1" should be listed as "Editor" in the collaborators list on the webUI
    And group "grp2" should be listed as "Editor" in the collaborators list on the webUI
    When the user deletes "grp1" as collaborator for the current file using the webUI
    Then group "grp1" should not be listed in the collaborators list on the webUI
    And group "grp2" should be listed as "Editor" in the collaborators list on the webUI
    And file "lorem.txt" should be listed in shared-with-others page on the webUI
    And as "user2" file "lorem (2).txt" should not exist
    But as "user3" file "lorem (2).txt" should exist

  Scenario Outline: share a file with multiple users with different roles and permissions
    Given user "user0" has been created with default attributes
    And group "grp2" has been created
    And user "user2" has been added to group "grp2"
    And user "user1" has logged in using the webUI
    When the user opens the share dialog for file "lorem.txt" using the webUI
    And the user selects the following collaborators for the share as "<role>" with "<extra-permissions>" permissions:
      | collaborator | type  |
      | grp1         | group |
      | User Three   | user  |
      | grp2         | group |
    And the user removes "grp1" as a collaborator from the share
    And the user shares with the selected collaborators
    Then custom permissions "<displayed-permissions>" should be set for user "grp2" for file "lorem.txt" on the webUI
    And custom permissions "<displayed-permissions>" should be set for user "User Three" for file "lorem.txt" on the webUI
    And group "grp2" should be listed as "<displayed-role>" in the collaborators list for file "lorem.txt" on the webUI
    And user "User Three" should be listed as "<displayed-role>" in the collaborators list for file "lorem.txt" on the webUI
    And user "user2" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user1                |
      | share_with  | grp2                 |
      | file_target | /lorem (2).txt       |
      | item_type   | file                 |
      | permissions | <actual-permissions> |
    And user "user3" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user1                |
      | share_with  | user3                |
      | file_target | /lorem (2).txt       |
      | item_type   | file                 |
      | permissions | <actual-permissions> |
    But user "User One" should not be listed in the collaborators list on the webUI
    And group "grp1" should not be listed in the collaborators list on the webUI
    And as "user1" file "lorem (2).txt" should not exist
    Examples:
      | role        | displayed-role | extra-permissions | displayed-permissions | actual-permissions  |
      | Viewer      | Viewer         | share             | share                 | read, share         |
      | Viewer      | Viewer         | ,                 | ,                     | read                |
      | Editor      | Editor         | share             | share                 | share, read, change |
      | Editor      | Editor         | ,                 | ,                     | read, change        |
      | Custom Role | Viewer         | ,                 | ,                     | read                |
      | Custom Role | Viewer         | share             | share                 | read, share         |
      | Custom Role | Editor         | change            | ,                     | read, change        |
      | Custom Role | Editor         | share, change     | share                 | read, change, share |

  @issue-1837 @issue-1897
  Scenario Outline: share a folder with multiple users with different roles and permissions
    Given group "grp2" has been created
    And user "user2" has been added to group "grp2"
    And user "user1" has logged in using the webUI
    When the user opens the share dialog for folder "simple-folder" using the webUI
    And the user selects the following collaborators for the share as "<role>" with "<extra-permissions>" permissions:
      | collaborator | type  |
      | grp1         | group |
      | User Three   | user  |
      | grp2         | group |
    And the user removes "grp1" as a collaborator from the share
    And the user removes "User One" as a collaborator from the share
    And the user shares with the selected collaborators
    Then custom permissions "<displayed-permissions>" should be set for user "grp2" for folder "simple-folder" on the webUI
    And custom permissions "<displayed-permissions>" should be set for user "User Three" for folder "simple-folder" on the webUI
    And group "grp2" should be listed as "<displayed-role>" in the collaborators list for folder "simple-folder" on the webUI
    And user "User Three" should be listed as "<displayed-role>" in the collaborators list for folder "simple-folder" on the webUI
    And user "user2" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user1                |
      | share_with  | grp2                 |
      | file_target | /simple-folder (2)   |
      | item_type   | folder               |
      | permissions | <actual-permissions> |
    And user "user3" should have received a share with these details:
      | field       | value                |
      | uid_owner   | user1                |
      | share_with  | user3                |
      | file_target | /simple-folder (2)   |
      | item_type   | folder               |
      | permissions | <actual-permissions> |
    But user "User One" should not be listed in the collaborators list on the webUI
    And group "grp1" should not be listed in the collaborators list on the webUI
    And as "user1" folder "simple-folder (2)" should not exist
    Examples:
      | role        | displayed-role | extra-permissions             | displayed-permissions | actual-permissions           |
      | Viewer      | Viewer         | share                         | share                 | read, share                  |
      | Viewer      | Viewer         | ,                             | ,                     | read                         |
      | Editor      | Editor         | share                         | share                 | all                          |
      | Editor      | Editor         | ,                             | ,                     | read, change, delete, create |
      | Custom Role | Viewer         | ,                             | ,                     | read                         |
      | Custom Role | Viewer         | share                         | share                 | read, share                  |
      | Custom Role | Custom role    | delete                        | delete                | read, delete                 |
      # issue-1897: Displayed role below should have been 'Custom role'
      | Custom Role | Editor         | change                        | ,                     | read, change                 |
      | Custom Role | Custom role    | create                        | create                | read, create                 |
      | Custom Role | Custom role    | share, delete                 | share, delete         | read, share, delete          |
      # issue-1897: Displayed role below should have been 'Custom role'
      | Custom Role | Editor         | share, change                 | share                 | read, change, share          |
      | Custom Role | Custom role    | share, create                 | share, create         | read, share, create          |
      | Custom Role | Custom role    | delete, change                | delete, change        | read, delete, change         |
      | Custom Role | Custom role    | delete, create                | delete, create        | read, delete, create         |
      | Custom Role | Custom role    | change, create                | change, create        | read, change, create         |
      # issue-1837: Displayed Permissions below should have been 'share, delete, change'
      | Custom Role | Custom role    | share, delete, change         | ,                     | read, share, delete, change  |
      # issue-1837: Displayed Permissions below should have been 'share, create, delete'.
      | Custom Role | Custom role    | share, create, delete         | ,                     | read, share, delete, create  |
      # issue-1837: Displayed Permissions below should have been 'share, change, create'.
      | Custom Role | Custom role    | share, change, create         | ,                     | read, share, change, create  |
      | Custom Role | Editor         | delete, change, create        | ,                     | read, delete, change, create |
      | Custom Role | Editor         | share, delete, change, create | share                 | all                          |