trigger TaskReminder on Task (before delete) {
	System.debug('Remind me about tasks');
}