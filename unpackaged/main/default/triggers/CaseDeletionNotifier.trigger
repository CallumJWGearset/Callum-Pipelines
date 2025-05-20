trigger CaseDeletionNotifier on Case (before delete) {
	System.debug('Remind me about deleted Cases');
}