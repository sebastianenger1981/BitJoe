package org.bushe.swing.event.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import org.bushe.swing.event.EventService;
import org.bushe.swing.event.EventServiceLocator;
import org.bushe.swing.event.ThreadSafeEventService;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface EventTopicPatternSubscriber {
   /** The Regular Expression to subscribe to. */
   String topicPattern();

   /** Whether or not to subcribe to the exact class or a class hierarchy, defaults to class hierarchy (false). */
   boolean exact() default false;

   /** Whether to subscribe weakly or strongly. */
   ReferenceStrength referenceStrength() default ReferenceStrength.WEAK;

   /** The event service to subscribe to, default to the EventServiceLocator.SERVICE_NAME_EVENT_BUS. */
   String eventServiceName() default EventServiceLocator.SERVICE_NAME_EVENT_BUS;

   /**
    * Whether or not to autocreate the event service if it doesn't exist on subscription, default is true. If the
    * service needs to be created, it must have a default constructor.
    */
   Class<? extends EventService> autoCreateEventServiceClass() default ThreadSafeEventService.class;
}
