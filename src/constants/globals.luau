local RunService = game:GetService("RunService")
return {
    IS_SERVER = RunService:IsServer(),
    IS_CLIENT = RunService:IsClient(),
    IS_STUDIO = RunService:IsStudio(),
}