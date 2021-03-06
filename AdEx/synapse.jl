# AdEx Neuron implementation

abstract type AdEx_Synapse end

## Transmission current functions
AdEx_Synapse_I(s::AdEx_Synapse, t, V) = s.g * ((s.E_syn + V) * 1e3);
AdEx_Synapse_I_D(s::AdEx_Synapse, t, V) = s.g * (s.a_scale * s.D) * ((s.E_syn + V) * 1e3);
AdEx_Synapse_I_F(s::AdEx_Synapse, t, V) = s.g * (s.b_scale * s.F) * ((s.E_syn + V) * 1e3);

AdEx_Synapse_dDdt(s::AdEx_Synapse, n::AdEx_Neuron, t, D) = (1 - D) / s.τ_D1 - (D * AdEx_Neuron_I(n, t)) / s.τ_D2;
AdEx_Synapse_dDdt(s::AdEx_Synapse, n::AdEx_Neuron, t) = (1 - s.D) / s.τ_D1 - (s.D * AdEx_Neuron_I(n, t)) / s.τ_D2;

AdEx_Synapse_dFdt(s::AdEx_Synapse, n::AdEx_Neuron, t, F) = (1 - F) / s.τ_F1 - (F * AdEx_Neuron_I(n, t)) / s.τ_F2;
AdEx_Synapse_dFdt(s::AdEx_Synapse, n::AdEx_Neuron, t) = (1 - s.F) / s.τ_F1 - (s.F * AdEx_Neuron_I(n, t)) / s.τ_F2;

## NMDA synapse
@with_kw mutable struct AdEx_Synapse_NMDA <: AdEx_Synapse
    g_history::Array{AdEx_Float} = AdEx_Float[];
    I_history::Array{AdEx_Float} = AdEx_Float[];
    PreSyn::Int = -1
    PostSyn::Int = -1
    g_c_NMDA::AdEx_Float = 1.5nS
    τ_rise::AdEx_Float = 3ms
    τ_decay::AdEx_Float = 40ms
    Mg2p::AdEx_Float = 1.2mM
    α::AdEx_Float = (0.062mV)^-1
    β::AdEx_Float = 1 / 3.57mM
    g::AdEx_Float = 0nS
    I::AdEx_Float = 0mV
    E_syn::AdEx_Float = 0mV
    F::AdEx_Float = 1
    τ_F1 = 1500ms
    τ_F2 = 100ms
    b_scale = 3
end

AdEx_Synapse_g(s::AdEx_Synapse_NMDA, t, t_f, V) = s.g_c_NMDA * (1 - exp(-((t - t_f) / s.τ_rise))) * exp(-((t - t_f) / s.τ_decay)) * (1 + s.β * exp(-s.α * V) * s.Mg2p)^(-1) * Θ(t - t_f);

## GABA synapses
@with_kw mutable struct AdEx_Synapse_GABA_A <: AdEx_Synapse
    g_history::Array{AdEx_Float} = AdEx_Float[];
    I_history::Array{AdEx_Float} = AdEx_Float[];
    PreSyn::Int = -1
    PostSyn::Int = -1
    a::AdEx_Float = 1
    τ_rise::AdEx_Float = 1ms
    τ_fast::AdEx_Float = 6ms
    E_syn::AdEx_Float = -75mV
    g::AdEx_Float = 0nS
    g_c_GABA_A::AdEx_Float = 40nS
    I::AdEx_Float = 0mV
    D::AdEx_Float = 1
    τ_D1 = 1000ms
    τ_D2 = 250ms
    a_scale = 1.7
end

AdEx_Synapse_g(s::AdEx_Synapse_GABA_A, t, t_f, V) = s.g_c_GABA_A * (1 - exp(-((t - t_f) / s.τ_rise))) * (s.a * exp(-((t - t_f) / s.τ_fast))) * Θ(t - t_f);

@with_kw mutable struct AdEx_Synapse_GABA_B <: AdEx_Synapse
    g_history::Array{AdEx_Float} = AdEx_Float[];
    I_history::Array{AdEx_Float} = AdEx_Float[];
    PreSyn::Int = -1
    PostSyn::Int = -1
    a::AdEx_Float = 0.8
    τ_rise::AdEx_Float = 20ms
    τ_fast::AdEx_Float = 100ms
    τ_slow::AdEx_Float = 500ms
    E_syn::AdEx_Float = -75mV
    g::AdEx_Float = 0nS
    g_c_GABA_B::AdEx_Float = 40nS
    I::AdEx_Float = 0mV
    D::AdEx_Float = 1
    τ_D1 = 1000ms
    τ_D2 = 250ms
    a_scale = 1.7
end

AdEx_Synapse_g(s::AdEx_Synapse_GABA_B, t, t_f, V) = s.g_c_GABA_B * (1 - exp(-((t - t_f) / s.τ_rise))) * (s.a * exp(-((t - t_f) / s.τ_fast)) + (1 - s.a) * exp(-((t - t_f) / s.τ_slow))) * Θ(t - t_f);

## AMPA synapse
@with_kw mutable struct AdEx_Synapse_AMPA <: AdEx_Synapse
    g_history::Array{AdEx_Float} = AdEx_Float[];
    I_history::Array{AdEx_Float} = AdEx_Float[];
    PreSyn::Int = -1
    PostSyn::Int = -1
    g_c_AMPA::AdEx_Float = 40nS
    g::AdEx_Float = 0nS
    τ::AdEx_Float = 5ms
    I::AdEx_Float = 0mV
    E_syn::AdEx_Float = 0mV
    F::AdEx_Float = 1
    τ_F1 = 1500ms
    τ_F2 = 100ms
    b_scale = 3
end

AdEx_Synapse_g(s::AdEx_Synapse_AMPA, t, t_f, V) = s.g_c_AMPA * exp(-((t - t_f) / s.τ)) * Θ(t - t_f);
