package serialization.tests

import std.unittest.*

import serialization.macros.Serialize

@Serialize
class BaseTestClass {
    let x: Int64 = 5
    let y: String = "y"
}

@Test
func baseTest() {
    let baseClass = BaseTestClass()
    let outputString: String = baseClass.toJsonString()

    @Expect(outputString.contains("\"x\": \"5\""), true)
    @Expect(outputString.contains("\"y\": \"y\""), true)
}