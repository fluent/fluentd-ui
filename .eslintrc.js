module.exports = {
  "env": {
    "browser": true,
    "es6": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:vue/recommended"
  ],
  "parserOptions": {
    "ecmaVersion": 2017,
    "sourceType": "module"
  },
  "globals": {
    "$": true,
    "Rails": true,
    "Vue": true
  },
  "rules": {
    "indent": [
      "error",
      2
    ],
    "linebreak-style": [
      "error",
      "unix"
    ],
    "quotes": [
      "error",
      "double"
    ],
    "semi": [
      "error",
      "always"
    ],
    "no-console": [
      "off"
    ],
    "no-unused-vars": [
      "off", {
        "argsIgnorePattern": "^_"
      }
    ]
  }
};
