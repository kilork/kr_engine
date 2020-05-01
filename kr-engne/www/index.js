import * as wasm from "kr-engne";
import {
    memory
} from "kr-engne/kr_engne_bg";

const canvas = document.getElementById("canvas");

const ctx = canvas.getContext('2d');
const width = canvas.width;
const height = canvas.height;

const universum = wasm.Universum.new(width, height);

console.log(`canvas: ${width}:${height}`);

// const memoryPtr = universum.buffer();
// const buffer = new Uint8ClampedArray(memory.buffer, memoryPtr, width * height * 4);
// const imageData = new ImageData(buffer, width, height);

universum.init_defaults();

const renderLoop = () => {
    universum.tick();
    requestAnimationFrame(renderLoop);
};

requestAnimationFrame(renderLoop);
