package config

import org.springframework.context.annotation._
import org.springframework.context.{ApplicationContext, ApplicationContextAware}

/** Experiments definitions for the 'peel-wordcount' bundle. */
@Configuration
@ComponentScan( // Scan for annotated Peel components in the 'org.peelframework.wordcount' package
  value = Array("org.peelframework.wordcount"),
  useDefaultFilters = false,
  includeFilters = Array[ComponentScan.Filter](
    new ComponentScan.Filter(value = Array(classOf[org.springframework.stereotype.Service])),
    new ComponentScan.Filter(value = Array(classOf[org.springframework.stereotype.Component]))
  )
)
@ImportResource(value = Array(
  "classpath:peel-core.xml",
  "classpath:peel-extensions.xml"
))
@Import(value = Array(
  classOf[config.fixtures.systems],  // custom system beans
  classOf[config.fixtures.wordcount] // wordcount experiment beans
))
class experiments extends ApplicationContextAware {

  /* The enclosing application context. */
  var ctx: ApplicationContext = null

  def setApplicationContext(ctx: ApplicationContext): Unit = {
    this.ctx = ctx
  }
}