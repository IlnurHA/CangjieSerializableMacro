package serialization.tests

import std.unittest.*

import serialization.macros.{Serialize, SerializationExcludeField, SerializationIncludeProperty}

@Serialize
class IncludeTestClass {
    @SerializationExcludeField let x: Int64 = 5
    @SerializationExcludeField let y: String = "y"

    public prop myX: Int64 {
        get() { this.x }
    }

    @SerializationIncludeProperty
    public prop myY: String {
        get() { this.y }
    }
}

@Test
func includePropTest() {
    let includeTestClass = IncludeTestClass()
    let outputString: String = includeTestClass.toJsonString()

    @Expect(outputString.contains("\"x\": \"5\""), false)
    @Expect(outputString.contains("\"y\": \"y\""), false)
    @Expect(outputString.contains("\"myX\": \"5\""), false)
    @Expect(outputString.contains("\"myY\": \"y\""), true)
}