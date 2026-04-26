package serialization.tests

import serialization.macros.{Serialize, SerializationExcludeField, SerializationIncludeProperty}

@Serialize
class TestSubClass {
    let abc: String = "abc"
}

@Serialize
class FullTest {
    let x: Int64
    var y: String = "y"
    let testSubClass: TestSubClass = TestSubClass()

    @SerializationExcludeField let arr: Array<Int64>
    @SerializationExcludeField var w: String = "W"

    public init(x: Int64, arr: Array<Int64>) {
        this.x = x;
        this.arr = arr;
    }

    @SerializationIncludeProperty
    public prop myAbc: String {
        get() {
            this.testSubClass.abc
        }
    }
}
 

@Test[x in [1, 2, 3]]
func fullTest(x: Int64, ) {
    let fullTestClass = FullTest(x, [1, 2, 3])
    let outputString: String = fullTestClass.toJsonString()

    @Expect(outputString.contains("\"x\": \"${x}\""), true)
    @Expect(outputString.contains("\"y\": \"y\""), true)
    @Expect(outputString.contains("arr"), false)
    @Expect(outputString.contains("w"), false)
    @Expect(outputString.contains("\"testSubClass\": {\"abc\": \"abc\"}"), true)
    @Expect(outputString.contains("\"myAbc\": \"abc\""), true)
}