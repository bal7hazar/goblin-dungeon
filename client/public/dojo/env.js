const DEV = window.location.href.includes('dev');

const dev = {
    NODE_URL: "http://localhost:5050",
    TORII_URL: "http://localhost:8080",
    RELAY_URL: "/ip4/127.0.0.1/tcp/9090",
    WORLD_ADDRESS: "0x3b092891f7d869d9255225311da9ffd7a090c851b7ea5de92ea162e5b4dfcd6",
    SYSTEM_ADDRESS: "0x03022cd638babf65f15e26ebc9e85a2413bedd9b6580db12b8dd0a8516c4bcfa",
    MASTER_ADDRESS: "0xb3ff441a68610b30fd5e2abbf3a1548eb6ba6f3559f2862bf2dc757e5828ca",
    MASTER_PRIVATE_KEY: "0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a",
}

const slot = {
    NODE_URL: "https://api.cartridge.gg/x/grimscape/katana",
    TORII_URL: "https://api.cartridge.gg/x/grimscape/torii",
    RELAY_URL: "/ip4/127.0.0.1/tcp/9090",
    WORLD_ADDRESS: "0x1b27c5db43d03721c5025a4309adc91d061f02f4f49f2b5310effcd19897bde",
    SYSTEM_ADDRESS: "0x04726d22f268d0718d4b076fb37f5a2bed74982731fa00cf1fbdec9994f4129f",
    MASTER_ADDRESS: "0x132b64272baaa3914d87a37c9b8034171601fc41976e8b9ffaf54d6ed9db3f8",
    MASTER_PRIVATE_KEY: "0x212362587a24cb437514f8902d2e2f0b214ff805eac68513956df52024fb878",
}

export const config = {
    NODE_URL: DEV ? dev.NODE_URL : slot.NODE_URL,
    TORII_URL: DEV ? dev.TORII_URL : slot.TORII_URL,
    RELAY_URL: DEV ? dev.RELAY_URL : slot.RELAY_URL,
    WORLD_ADDRESS: DEV ? dev.WORLD_ADDRESS : slot.WORLD_ADDRESS,
    SYSTEM_ADDRESS: DEV ? dev.SYSTEM_ADDRESS : slot.SYSTEM_ADDRESS,
    MASTER_ADDRESS: DEV ? dev.MASTER_ADDRESS : slot.MASTER_ADDRESS,
    MASTER_PRIVATE_KEY: DEV ? dev.MASTER_PRIVATE_KEY : slot.MASTER_PRIVATE_KEY,
};