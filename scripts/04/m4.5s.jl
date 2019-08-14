using StanModels, CSV

howell1 = CSV.read(joinpath(@__DIR__, "..", "..", "data", "Howell1.csv"), delim=';')
df = filter(row -> row[:age] >= 18, howell1)
df[!, :weight_s] = (df[!, :weight] .- mean(df[!, :weight])) / std(df[!, :weight]);
df[!, :weight_s2] = df[!, :weight_s] .^ 2;

# Define the Stan language model

weightsmodel = "
data{
    int N;
    real height[N];
    real weight_s2[N];
    real weight_s[N];
}
parameters{
    real a;
    real b1;
    real b2;
    real sigma;
}
model{
    vector[N] mu;
    sigma ~ uniform( 0 , 50 );
    b2 ~ normal( 0 , 10 );
    b1 ~ normal( 0 , 10 );
    a ~ normal( 178 , 100 );
    for ( i in 1:N ) {
        mu[i] = a + b1 * weight_s[i] + b2 * weight_s2[i];
    }
    height ~ normal( mu , sigma );
}
";

# Define the Stanmodel and set the output format to :mcmcchains.

sm = SampleModel("m4.5s", weightsmodel);

# Input data for cmdstan

heightsdata = Dict("N" => size(df, 1), "height" => df[!, :height],
"weight_s" => df[!, :weight_s], "weight_s2" => df[!, :weight_s2]);

# Sample using cmdstan

(sample_file, log_file)= stan_sample(sm, data=heightsdata);

# Describe the draws
if !(sample_file == nothing)
  chn = read_samples(sm)
  describe(chn)
end