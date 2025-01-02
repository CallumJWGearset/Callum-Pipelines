public class FillInDataScheduler {
    public void Schedule() {
        System.schedule('GenerateDataAccount', '0 20 3 * * ?', new CreateAccountAndRelated());
        System.schedule('GenerateOtherRecords', '0 15 4 * * ?', new CreateRecords());
    }
}