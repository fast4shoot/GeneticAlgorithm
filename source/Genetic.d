module genetic;
import individual;
import std.random;

Individual!fitness getFittest(alias fitness)(Individual!(fitness)[] population)
{
	import std.algorithm.searching : minElement;
	return population.minElement!"a.fitness";
}

Individual!fitness tournamentSelection(alias fitness)(Individual!fitness[] population, size_t tournamentSize)
{
    import std.range;
	randomShuffle(population);
	return population.drop(tournamentSize).getFittest();
}

Individual!fitness rouletteSelection(alias fitness)(Individual!fitness[] population)
{
    import std.algorithm.iteration;
    import std.algorithm.sorting;
    population.sort!"a.fitness < b.fitness";
    double sum = 0.0;
    foreach(ref individual; population)
    {
        sum += individual.fitness;
    }
    auto gate = uniform!"[]"(0.0, sum);
    import std.stdio;
    foreach(ref individual; population)
    {
        gate -= individual.fitness;
        if(gate <= 0.0) return individual;
    }
    return population[$ - 1];
}

Individual!fitness[] evolvePopulation(alias fitness)(Individual!fitness[] population,float mutation)
{
	Individual!fitness[] newPopulation;
	newPopulation ~= population.getFittest;
	foreach(i; 1..population.length)
	{
		auto a = population.tournamentSelection!fitness(5);
		auto b = population.tournamentSelection!fitness(5);
		newPopulation ~= a.crossover(b).mutate(mutation);
	}
	return newPopulation;
}

Individual!fitness geneticAlgorithm(alias fitness, alias print)(size_t genomSize, double requiredFitness,
                                                                size_t populationSize, float mutationRate)
{
	import std.stdio: writeln;
	Individual!fitness[] current;
	foreach(i; 1..populationSize)
	{
		current ~= new Individual!fitness(genomSize);
	}
	size_t generationNumber = 0;
	double bestFitness = double.max;
	while(current.getFittest.fitness > requiredFitness)
	{
		current = current.evolvePopulation!fitness(mutationRate);
        auto fittest = current.getFittest!fitness();
        if(fittest.fitness < bestFitness)
        {
            writeln(generationNumber, " => ", fittest.fitness);
            bestFitness = fittest.fitness;
        }
		generationNumber += 1;
	}
	writeln("==== Best genom =====");
	print(current.getFittest().genome());
	return current.getFittest();
}
