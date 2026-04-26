package serialization.tests

import std.unittest.*

import serialization.macros.{Serialize, SerializationExcludeField}

@Serialize
class ExcludeTestClass {
    let x: Int64 = 5
    
    @SerializationExcludeField let y: String = "y"
}

@Test
func excludeTest() {
    let excludeTestClass = ExcludeTestClass()
    let outputString: String = excludeTestClass.toJsonString()

    @Expect(outputString.contains("\"x\": \"5\""), true)
    @Expect(outputString.contains("\"y\": \"y\""), false)
}