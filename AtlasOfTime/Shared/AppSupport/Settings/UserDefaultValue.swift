import Foundation

@propertyWrapper
struct UserDefaultValue<Value> {
    private let key: String
    private let defaultValue: Value
    private let defaults: UserDefaults
    private let getter: (UserDefaults, String, Value) -> Value
    private let setter: (UserDefaults, String, Value) -> Void

    init(
        key: String,
        defaultValue: Value,
        defaults: UserDefaults = .standard,
        getter: @escaping (UserDefaults, String, Value) -> Value = { defaults, key, defaultValue in
            defaults.object(forKey: key) as? Value ?? defaultValue
        },
        setter: @escaping (UserDefaults, String, Value) -> Void = { defaults, key, value in
            defaults.set(value, forKey: key)
        }
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
        self.getter = getter
        self.setter = setter
    }

    var wrappedValue: Value {
        get { getter(defaults, key, defaultValue) }
        nonmutating set { setter(defaults, key, newValue) }
    }
}

@propertyWrapper
struct UserDefaultRawRepresentable<Value: RawRepresentable> where Value.RawValue == String {
    private let key: String
    private let defaultValue: Value
    private let defaults: UserDefaults

    init(
        key: String,
        defaultValue: Value,
        defaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }

    var wrappedValue: Value {
        get {
            guard let rawValue = defaults.string(forKey: key),
                  let value = Value(rawValue: rawValue) else {
                return defaultValue
            }
            return value
        }
        nonmutating set {
            defaults.set(newValue.rawValue, forKey: key)
        }
    }
}
