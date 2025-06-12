# auctionProyect Smart Contract

Este contrato inteligente implementa una subasta segura y dinámica en Solidity. Incluye funcionalidades como ofertas crecientes, reintegros, extensión de tiempo automático, reembolsos parciales, finalización manual y devolución de depósitos con comisión.

---

## Despliegue

1. Copiar el contrato a [Remix IDE](https://remix.ethereum.org).
2. Seleccionar compilador `Solidity 0.8.x`.
3. Compilar y desplegar usando una red VM.
4. Interactuar con las funciones del contrato desde la interfaz de Remix.

---

## Funcionalidades

### `constructor()`

- Inicializa la subasta con una duración de 14 días.
- Establece el tiempo de inicio (`startTime`) y fin (`stopTime`).

---

### `function bid() external payable`

Permite realizar una oferta durante la subasta.

- La oferta debe ser al menos un 5% mayor a la oferta actual.
- Registra la oferta válida más reciente por usuario.
- Extiende la subasta 10 minutos si la oferta se realiza dentro de los últimos 10 minutos.
- Emite el evento `NewOffer`.

---

### `function showWinner() external view returns (address, uint256)`

Devuelve el ganador actual (dirección) y el valor de su oferta.

---

### `function showOffers() external view returns (Bider[] memory)`

Devuelve la lista de todas las ofertas registradas con sus valores y oferentes.

---

### `function endAuction() external`

Finaliza manualmente la subasta antes de su tiempo límite.

- Solo puede ejecutarse una vez.
- Emite el evento `AuctionEnded`.

---

### `function withdraw() external onlyAfterEnd`

Permite a los **oferentes perdedores** retirar su depósito **con un descuento del 2%**.

- El ganador no puede usar esta función.
- Emite el evento `FullRefund`.

---

### `function partialRefound() external auctionActive`

Permite a un oferente retirar el exceso de ETH depositado **por encima de su última oferta válida** mientras la subasta sigue activa.

- Emite el evento `PartialRefund`.

---

## Variables Importantes

| Variable | Tipo | Descripción |
|----------|------|-------------|
| `startTime` | `uint256` | Tiempo de inicio de la subasta. |
| `stopTime` | `uint256` | Tiempo de finalización. |
| `ended` | `bool` | Indica si fue finalizada manualmente. |
| `winner` | `Bider` | Guarda al actual mayor postor. |
| `allBids` | `Bider[]` | Lista de todas las ofertas realizadas. |
| `deposits` | `mapping` | ETH depositado por cada oferente. |
| `latestValidBid` | `mapping` | Última oferta válida por dirección. |

---

## Eventos

| Evento | Descripción |
|--------|-------------|
| `NewOffer(address indexed bidder, uint256 amount)` | Emitido cuando se hace una nueva oferta válida. |
| `AuctionEnded(address winner, uint256 amount)` | Emitido cuando se termina la subasta. |
| `PartialRefund(address indexed bidder, uint256 amount)` | Emitido cuando un usuario retira el exceso de fondos. |
| `FullRefund(address indexed bidder, uint256 amount)` | Emitido cuando un perdedor retira su depósito (98%). |


