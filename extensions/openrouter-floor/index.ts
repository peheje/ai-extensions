import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const OPENROUTER_FLOOR_SUFFIX = ":floor";

function withOpenRouterFloor(model: unknown) {
	if (typeof model !== "string") return model;
	if (model.endsWith(OPENROUTER_FLOOR_SUFFIX)) return model;
	return `${model}${OPENROUTER_FLOOR_SUFFIX}`;
}

export default function (pi: ExtensionAPI) {
	pi.on("before_provider_request", (event, ctx) => {
		const model = ctx.model;
		if (!model) return;

		const isOpenRouter = model.provider === "openrouter" ||
			model.baseUrl.includes("openrouter.ai");
		if (!isOpenRouter) return;

		return {
			...event.payload,
			model: withOpenRouterFloor(event.payload.model),
		};
	});
}
