import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("before_provider_request", (event, ctx) => {
		const model = ctx.model;
		if (!model) return;

		const isOpenRouter = model.provider === "openrouter" ||
			model.baseUrl.includes("openrouter.ai");
		if (!isOpenRouter) return;

		return {
			...event.payload,
			session_id: ctx.sessionManager.getSessionId(),
		};
	});
}
