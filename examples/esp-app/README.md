# mcu project esp-idf application examples

## Project Commands

### Configuration
```shell
# gnu generator
cmake -Bbuild .

# or ninja generator
cmake -Bbuild -GNinja .
```

### Build
```shell
cmake --build build
```

### IDF Configuration
```shell
cmake --build build -t menuconfig
```

### Flash

```shell
cmake --build build -t flash
```
