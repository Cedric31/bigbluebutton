# --------------------------------------------------------------------------------------------
# Private methods on server
# --------------------------------------------------------------------------------------------
@addMeetingToCollection = (meetingId, name, intendedForRecording, voiceConf, duration) ->
  #check if the meeting is already in the collection

  obj = Meteor.Meetings.upsert({meetingId:meetingId}, {$set: {
    meetingName:name
    intendedForRecording: intendedForRecording
    currentlyBeingRecorded: false # defaut value
    voiceConf: voiceConf
    duration: duration
    roomLockSettings:
      # by default the lock settings will be disabled on meeting create
      disablePrivateChat: false
      disableCam: false
      disableMic: false
      lockOnJoin: Meteor.config.lockOnJoin
      lockedLayout: false
      disablePublicChat: false
      lockOnJoinConfigurable: false # TODO
  }}, (err, numChanged) ->
    if numChanged.insertedId?
      Meteor.log.error "added MEETING #{meetingId}")



@clearMeetingsCollection = (meetingId) ->
	if meetingId?
		Meteor.Meetings.remove({meetingId: meetingId}, Meteor.log.info "cleared Meetings Collection (meetingId: #{meetingId}!")
	else
		Meteor.Meetings.remove({}, Meteor.log.info "cleared Meetings Collection (all meetings)!")


#clean up upon a meeting's end
@removeMeetingFromCollection = (meetingId) ->
	if Meteor.Meetings.findOne({meetingId: meetingId})?
		Meteor.log.info "end of meeting #{meetingId}. Clear the meeting data from all collections"
		# delete all users in the meeting
		clearUsersCollection(meetingId)

		# delete all slides in the meeting
		clearSlidesCollection(meetingId)

		# delete all shapes in the meeting
		clearShapesCollection(meetingId)

		# delete all presentations in the meeting
		clearPresentationsCollection(meetingId)

		# delete all chat messages in the meeting
		clearChatCollection(meetingId)

		# delete the meeting
		clearMeetingsCollection(meetingId)
# --------------------------------------------------------------------------------------------
# end Private methods on server
# --------------------------------------------------------------------------------------------
