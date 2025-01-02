trigger TaskUpdate on Task (before update) {
	System.debug('Updated tasks');
}