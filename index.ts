import { runApplication } from "elementary-ui-browser-runtime";
import appInit from "virtual:swift-wasm?init&product=BluetoothExplorer";

await runApplication(appInit);
