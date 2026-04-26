# Naive Serializable Macro

```cangjie
package testSerialization

import serialization.macros.{Serialize, SerializationExcludeField, SerializationIncludeProperty}

@Serialize
class TestSubClass {
    let abc: String = "abc"
}

@Serialize
class Test {
    let x: Int64
    var y: String = "y"
    let testSubClass: TestSubClass = TestSubClass()

    @SerializationExcludeField let arr: Array<Int64>
    @SerializationExcludeField var z: String = "Z"

    public init(x: Int64, arr: Array<Int64>) {
        this.x = x;
        this.arr = arr;
    }

    @SerializationIncludeProperty
    public prop abc: String {
        get() {
            this.testSubClass.abc
        }
    }
}

main(): Int64 {
    let t = Test(5, [1, 2, 3])
    println("${t.toJsonString()}")
    return 0
}
```

## Usage

1. Install Cangjie 1.1.0 (e.g. from [nightly builds](https://gitcode.com/Cangjie/nightly_build/releases))

2. Clone repository:

    ```bash
    git clone https://github.com/IlnurHA/CangjieSerializableMacro.git
    ```

3. Create project using `cjpm` (that should be installed together with Cangjie):

    ```bash
    mkdir myProject
    cjpm init
    ```

4. Change `cjpm.toml` file to add `CangjieSerializableMacro` as dependency:

    ```toml
    [dependencies]
        [dependencies.serialization]
            path = "/path/to/CangjieSerializableMacro"
    ```

5. (Optional) Add compile option "--debug-macro" to see macro expansions in `cjmp.toml`:

    ```toml
      compile-option = "--debug-macro"
    ```