package serialization.tests

import std.unittest.*

import serialization.macros.{Serialize}

@Serialize
class ABC {
    let abc: String = "abc"
}

@Serialize
class ComplexTestClass {
    let abc: ABC = ABC()
}

@Test
func complexTest() {
    let complexTestClass = ComplexTestClass()
    let outputString: String = complexTestClass.toJsonString()

    @Expect(outputString, "{\"abc\": {\"abc\": \"abc\"}}")
}