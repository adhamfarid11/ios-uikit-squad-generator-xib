bazel clean --expunge && bazel shutdown && bazel build //squad-generator-xib:App

bazel run //squad-generator-xib/Modules/NameGenerator:App --define=generator_feature=on
