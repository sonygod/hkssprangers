class Test {
    static function main() {
        utest.UTest.run([
            new TestNextTimeSlots(),
            new TestTelegramTools(),
        ]);
    }
}
