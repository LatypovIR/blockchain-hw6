# Flashloan swap

Вся логика ```flash swap``` реализована в контракте ```TestFlashSwap```

Для тестирования во время ```flash swap``` в функции ```uniswapV2Call``` были произведены три простых swap-а
Циклический маршрут: ```wETH -> LINK -> DAI -> wETH```

Для запуска используйте команду ```npx hardhat test```
В файле ```hardhat.config.js``` можете поменять ```fork``` ссылку, если нужно

Пример вывода логов:

```
Uniswap
    For [0x7A28cf37763279F774916b85b5ef8b64AB421f79] has USDC = [10000], wETH = [0]
    
Start flash swap
      For owner: [0x7a28cf37763279f774916b85b5ef8b64ab421f79] wallet:
            BORROW = [10000]
            wETH = [9000]
            LINK = [0]
            DAI = [0]
      For owner: [0x7a28cf37763279f774916b85b5ef8b64ab421f79] wallet:
            BORROW = [10000]
            wETH = [0]
            LINK = [1764000]
            DAI = [0]
      For owner: [0x7a28cf37763279f774916b85b5ef8b64ab421f79] wallet:
            BORROW = [10000]
            wETH = [0]
            LINK = [0]
            DAI = [8820000]
      For owner: [0x7a28cf37763279f774916b85b5ef8b64ab421f79] wallet:
            BORROW = [10000]
            wETH = [7200]
            LINK = [0]
            DAI = [0]
      For owner: [0x7a28cf37763279f774916b85b5ef8b64ab421f79] wallet:
            BORROW = [972]
            wETH = [7200]
            LINK = [0]
            DAI = [0]
    Finished flash swap

    For [0x7A28cf37763279F774916b85b5ef8b64AB421f79] has USDC = [972], wETH = [7200]
    ✔ Flash swapped (406ms)


  1 passing (4s)
```