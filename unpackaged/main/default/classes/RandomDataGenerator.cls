public class RandomDataGenerator {
    public Integer number(Integer multiplier, Integer minimum) {
        return minimum + Integer.valueOf(Math.random() * multiplier);
    }

    public Integer number(Integer multiplier) {
        return number(multiplier, 0);
    }

    public String fullName() {
        return Constants.FULL_NAMES[number(Constants.FULL_NAMES.size() - 1)];
    }

    public String companyName() {
        return Constants.COMPANY_NAMES[number(Constants.COMPANY_NAMES.size() - 1)];
    }

    public String sentence() {
        String subject = fullName();
        String verb = Constants.VERBS[number(Constants.VERBS.size() - 1)];
        String obj = Constants.OBJECTS[number(Constants.OBJECTS.size() - 1)];

        return subject + ' ' + verb + ' ' + obj + '.';
    }

    public String sentences(Integer count) {
        String result = '';

        for (Integer i = 0; i < count; i++) {
            result += sentence() + ' ';
        }

        return result;
    }

    public String string(Integer length) {
        String result = '';

        for (Integer i = 0; i < length; i++) {
            result += Constants.CHARACTERS.charAt(number(Constants.CHARACTERS.length() - 1));
        }

        return result;
    }

    public Date date(Date maximum) {
        return maximum.addYears(-number(10)).addDays(-number(10));
    }

    public Boolean bool() {
        return Math.random() > 0.5;
    }
}