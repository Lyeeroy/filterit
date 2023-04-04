# filterit

**typing "/fit" command to toggle the GUI.**

This addon is a chat filter for WoW version 3.3.5a. It creates a resizable frame where the user can input filter criteria to search for specific chat messages in real-time. The filtered messages are displayed in a separate chat frame within the addon's frame. The user can move the addon frame around and resize it using a resize button. The addon also features a clear button, a close button, and a "Filter:" label.

The search logic splits the search string into individual "&" groups, and processes each group to find matches with the chat message. It then checks if any of the search groups match the message by iterating over each search word in each group and checking if it can find a match with the message 

![alt text](https://media.discordapp.net/attachments/880419552670920745/1092850715774435480/image.png "1")
