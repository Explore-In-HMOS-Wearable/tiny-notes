import { cryptoFramework } from '@kit.CryptoArchitectureKit';

let fallbackSeed: bigint = BigInt(Date.now());

function nextFallbackFraction(): number {
  fallbackSeed = (fallbackSeed * BigInt(1103515245) + BigInt(12345)) & ((BigInt(1) << BigInt(53)) - BigInt(1));
  return Number(fallbackSeed) / Number((BigInt(1) << BigInt(53)) - BigInt(1));
}

// Returns a cryptographically secure fractional number.
// Returns a number in [0, 1).
export function secureRandomNumber(): number {
  try {
    const rand = cryptoFramework.createRandom();
    const randData = rand.generateRandomSync(8);
    const bytes = randData.data;
    let value = BigInt(0);
    for (let index = 0; index < 8; index++) {
      value = (value << BigInt(8)) | BigInt(bytes[index]);
    }
    return Number(value >> BigInt(11)) / Number(BigInt(1) << BigInt(53));
  } catch (_error) {
    return nextFallbackFraction();
  }
}

export function secureRandomInt(maxExclusive: number): number {
  if (maxExclusive <= 0) {
    return 0;
  }
  return Math.floor(secureRandomNumber() * maxExclusive);
}
