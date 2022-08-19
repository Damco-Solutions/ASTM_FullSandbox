/**
 * Created by William McCullough from OpenGate Consulting on 7/23/2019.
 */

@IsTest
private class CharsetTest {
    @isTest
    public static void test_encode() {
        System.assertEquals('2b3a418f8e99',
                EncodingUtil.convertToHex(Charset.encode('+:AÅÄÖ',
                        'cp437')));
    }
    @isTest
    public static void test_decode() {
        System.assertEquals('+:AÅÄÖ',
                Charset.decode(EncodingUtil.convertFromHex('2b3a418f8e99'),
                        'cp437'));
    }
}