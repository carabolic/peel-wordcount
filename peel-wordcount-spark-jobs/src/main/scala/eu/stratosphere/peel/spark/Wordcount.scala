package eu.stratosphere.peel.spark

import org.apache.spark.{SparkContext, SparkConf}

/**
 * Created by carabolic on 15/07/15.
 */
object Wordcount {

  def main(args: Array[String]) {
    if (args.length != 2) {
      return
    }

    val inputPath = args(0)
    val outputPath = args(1)

    val spark = new SparkContext()
    spark.textFile(inputPath)
      .flatMap { _.toLowerCase.split("\\W+") }
      .map { (_, 1) }
      .reduceByKey(_ + _).saveAsTextFile(outputPath)
  }

}
