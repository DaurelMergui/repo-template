const security = require('eslint-plugin-security');

module.exports = [
  security.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        require: 'readonly',
        module: 'readonly',
        process: 'readonly',
        console: 'readonly',
        __dirname: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': 'warn',
      'no-undef': 'error',
      // Flags every obj[key]; mostly false positives, so off. Review dynamic keys by hand.
      'security/detect-object-injection': 'off',
    },
  },
];
