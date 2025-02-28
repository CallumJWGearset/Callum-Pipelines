trigger TaskSendMessage on Task (after delete) {
	System.debug('Send message me about tasks');
}