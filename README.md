## ⚙️ Bazel Commands

### 🧹 Clean Bazel

```bash
bazel clean --expunge && bazel shutdown
```

---

### 🚀 Run Name Generator (Full Command)

```bash
bazel run //squad-generator-xib/Modules/NameGenerator:App --define=generator_feature=on
```

---

### ⚡ Simplified (Using .bazelrc)

```bash
bazel run --config=generator
```

---

## 🧠 Generator

**Build:**

```bash
bazel build --config=generator
```

**Run:**

```bash
bazel run --config=generator
```

---

## ⏱️ Timer

**Build:**

```bash
bazel build --config=timer
```

**Run:**

```bash
bazel run --config=timer
```

## 📚 Library

**Build:**

```bash
bazel build --config=library
```

**Run:**

```bash
bazel run --config=library
```

---

## 🤼‍♂️ Chats

**Build:**

```bash
bazel build --config=chats
```

**Run:**

```bash
bazel run --config=chats
```
