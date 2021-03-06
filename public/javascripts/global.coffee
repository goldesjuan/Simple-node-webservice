#Userlist data array for filling in info box
userListData = []

#DOM Ready =================================================================
$(document).ready ->
    #Populate the user table on initial page load
    populateTable()

    #Username link click
    $('#userList table tbody').on 'click', 'td a.linkshowuser', showUserInfo

    #Add user button click
    $('#btnAddUser').on 'click', addUser

    #Delete user link click
    $('#userList table tbody').on 'click', 'td a.linkdeleteuser', deleteUser

    #Email user link click
    $('#userList table tbody').on 'click', 'td a.linkemailuser', emailUser

    #Sms user link click
    $('#userList table tbody').on 'click', 'td a.linksmsuser', smsUser

#Functions =================================================================

#Fill table with data
populateTable = ->

    #Empty content string
    tableContent = ''

    $.getJSON 'userlist', (data) ->

        #Stick our user data array into a userlist variable in the global object
        userListData = data

        #For each item in our JSON, add a table row and cells to the content string
        $.each data, ->
            tableContent += '<tr>'
            tableContent += '<td><a href="#" class="linkshowuser" rel="' + this.username + '">' + this.username + '</a></td>'
            tableContent += '<td><a href="#" class="linkemailuser" rel="' + this.email + '">' + this.email + '</a></td>'
            tableContent += '<td><a href="#" class="linksmsuser" rel="' + this.phone + '">'+ if this.phone? then this.phone else 'no phone' + '</a></td>'
            tableContent += '<td><a href="#" class="linkdeleteuser" rel="' + this._id + '">delete</a></td>'
            tableContent += '</tr>'
            return

        #Inject the whole content string into our existing HTML table
        $('#userList table tbody').html tableContent
        return
    return

#Show user info
showUserInfo = (event) ->
    event.preventDefault

    #Retrieve username from rel attribute
    thisUserName = $(this).attr 'rel'

    #Get array position of user in userArray
    arrayPosition = userListData.map((arrayItem) -> arrayItem.username ).indexOf thisUserName

    #Retrieve user object from array.
    thisUserObject = userListData[arrayPosition]

    #Populate infoBox
    $('#userInfoName').text thisUserObject.fullname
    $('#userInfoAge').text thisUserObject.age
    $('#userInfoGender').text thisUserObject.gender
    $('#userInfoLocation').text thisUserObject.location
    return

#Add a new user
addUser = (event) ->
    event.preventDefault

    #Super basic validation - increase errorCount variable if any fields are blank
    errorCount = 0
    $('#addUser input').each (index, val) ->
        if $(this).val is ''
            errorCount++
        return

    #Make sure error count is still 0
    if errorCount is 0

        #If it is compile all info into one object
        newUser =
            'username': $('#addUser fieldset input#inputUserName').val(),
            'email': $('#addUser fieldset input#inputUserEmail').val(),
            'fullname': $('#addUser fieldset input#inputUserFullname').val(),
            'age': $('#addUser fieldset input#inputUserAge').val(),
            'location': $('#addUser fieldset input#inputUserLocation').val(),
            'gender': $('#addUser fieldset input#inputUserGender').val(),
            'phone' : $('#addUser fieldset input#inputUserPhone').val()

        #Use AJAX to post the object to the adduser service
        $.ajax(
            type : 'POST'
            data: newUser,
            url: '/adduser',
            dataType: 'JSON'
        ).done (response) ->
            if response.status is 200
                 #Clear form inputs
                $('#addUser fieldset input').val ''

                #Update the table
                populateTable()
            else if error?
                alert "Error #{response.error}"
    else
        #If error count is more than 0, alert error
        alert 'Please fill in all fields'
        return false
    return

#Delete user
deleteUser = (event) ->
    event.preventDefault

    #Pop up confirmation dialog
    confirmation = confirm 'Are you sure you want to delete this user?'

    #Check and make sure user confirmed
    if confirmation
        #if they did, then delete
        $.ajax(
            type: 'DELETE',
            url: "/users/#{$(this).attr 'rel'}",
            success : (response) ->
                #Update the table
                populateTable()
            error : (error) ->
                alert "error #{error}"
        )
    else
        #If they replied no to confirmation, do nothing
        return false
    return


#Send email to user
emailUser = (event) ->
    event.preventDefault

    userEmail = $(this).attr 'rel'

    # Pop up confirmation dialog
    confirmation = confirm 'Send email to ' + userEmail + '?'

    # Create JSON data
    emailData =
        'from' : 'Notifications <youremail@yourdomain.com>',
        'to' : userEmail,
        'subject' : 'Sent using Mailgun',
        'text' : 'This email has been sent using Mailgun API'

    # If user confirmed, send POST to postemail
    if confirmation
        $.ajax(
            type: 'POST',
            data: emailData,
            url: '/postemail',
            dataType: 'JSON'
        ).done (response) ->
            if response.status is 200
                alert 'Email sent'
            else
                alert 'Error sending email'
    else
        #If they replied no to confirmation, do nothing
        return false
    return

#Send sms to user

smsUser = (event) ->
    event.preventDefault

    userPhone = $(this).attr 'rel'

    # If phone is not empty send POST to sendsms
    if userPhone?

        # Promt user for message.
        message = prompt 'Please enter your message for ' + userPhone

        # Create JSON data
        smsData =
            'from' : '+12055066728'
            'to' : userPhone,
            'body' : message

        # Send post to postsms
        $.ajax(
            type : 'POST',
            data : smsData,
            url : '/postsms',
            dataType : 'JSON'
        ).done (response) ->
            if response.status is 200
                alert 'Message sent'
            else
                'Error sending message'
    else

        # Alert if phone is empty
        alert 'No phone number specified'
        return false
    return

