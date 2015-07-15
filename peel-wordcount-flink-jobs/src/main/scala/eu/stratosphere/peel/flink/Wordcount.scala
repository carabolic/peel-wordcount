package eu.stratosphere.peel.flink

import org.apache.flink.api.scala._

/**
 * Example Apache Flink Job that counts the word occurrences in a given dataset.
 *
 * This example is built on top of the Apache Flink Scala API.
 */
object Wordcount {

  def main (args: Array[String]) {
    if (args.length != 2) {
      return
    }

    val inputPath = args(0)
    val outputPath = args(1)

    val env = ExecutionEnvironment.getExecutionEnvironment
    env.readTextFile(inputPath)
      .flatMap { _.toLowerCase.split("\\W+") }
      .map { (_, 1) }
      .groupBy(0)
      .sum(1)
      .writeAsCsv(outputPath)

    env.execute()
  }

}
