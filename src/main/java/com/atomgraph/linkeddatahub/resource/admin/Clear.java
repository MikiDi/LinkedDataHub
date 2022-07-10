/**
 *  Copyright 2022 Martynas Jusevičius <martynas@atomgraph.com>
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package com.atomgraph.linkeddatahub.resource.admin;

import com.atomgraph.linkeddatahub.apps.model.AdminApplication;
import com.atomgraph.linkeddatahub.apps.model.EndUserApplication;
import static com.atomgraph.linkeddatahub.server.filter.request.OntologyFilter.addDocumentModel;
import com.atomgraph.linkeddatahub.server.util.OntologyModelGetter;
import com.atomgraph.processor.util.OntModelReadOnly;
import java.net.URI;
import java.util.List;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.POST;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.apache.jena.ontology.OntModel;
import org.apache.jena.ontology.OntModelSpec;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * JAX-RS resource that clears ontology from memory and reloads it.
 * Contains the same ontology loading query as <code>OntologyFilter</code>.
 * 
 * @author {@literal Martynas Jusevičius <martynas@atomgraph.com>}
 * @see com.atomgraph.linkeddatahub.server.filter.request.OntologyFilter
 */
public class Clear
{
    
    private static final Logger log = LoggerFactory.getLogger(Clear.class);

    private final com.atomgraph.linkeddatahub.apps.model.Application application;
    private final com.atomgraph.linkeddatahub.Application system;

    /**
     * Constructs endpoint.
     * 
     * @param application matched application
     * @param system system application
     */
    @Inject
    public Clear(com.atomgraph.linkeddatahub.apps.model.Application application, com.atomgraph.linkeddatahub.Application system)
    {
        this.application = application;
        this.system = system;
    }
    
    /**
     * Clears the specified ontology from memory.
     * 
     * @param ontologyURIs ontology URI
     * @param referer the referring URL
     * @return JAX-RS response
     */
    @POST
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    public Response post(@FormParam("uri") List<String> ontologyURIs, @HeaderParam("Referer") URI referer)
    {
        ontologyURIs.forEach(ontologyURI -> 
        {
            EndUserApplication app = getApplication().as(AdminApplication.class).getEndUserApplication(); // we're assuming the current app is admin
            OntModelSpec ontModelSpec = new OntModelSpec(getSystem().getOntModelSpec(app));
            if (ontModelSpec.getDocumentManager().getFileManager().hasCachedModel(ontologyURI))
            {
                ontModelSpec.getDocumentManager().getFileManager().removeCacheModel(ontologyURI);

                // !!! we need to reload the ontology model before returning a response, to make sure the next request already gets the new version !!!
                // same logic as in OntologyFilter. TO-DO: encapsulate?
                OntologyModelGetter modelGetter = new OntologyModelGetter(app,
                        ontModelSpec, getSystem().getOntologyQuery(), getSystem().getNoCertClient(), getSystem().getMediaTypes());
                ontModelSpec.setImportModelGetter(modelGetter);
                Model baseModel = modelGetter.getModel(ontologyURI);
                OntModel ontModel = ModelFactory.createOntologyModel(ontModelSpec, baseModel);
                // materialize OntModel inferences to avoid invoking rules engine on every request
                OntModel materializedModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM); // no inference
                materializedModel.add(ontModel);
                ontModel.getDocumentManager().addModel(ontologyURI, new OntModelReadOnly(materializedModel), true); // make immutable and add as OntModel so that imports do not need to be reloaded during retrieval
                // make sure to cache imported models not only by ontology URI but also by document URI
                ontModel.listImportedOntologyURIs(true).forEach((String importURI) -> addDocumentModel(ontModel.getDocumentManager(), importURI));
            }
        });
        
        if (referer != null) return Response.seeOther(referer).build();
        else return Response.ok().build();
    }
    
    /**
     * Returns the current application.
     * 
     * @return application resource
     */
    public com.atomgraph.linkeddatahub.apps.model.Application getApplication()
    {
        return application;
    }
    
    /**
     * Returns the system application.
     * 
     * @return JAX-RS application
     */
    public com.atomgraph.linkeddatahub.Application getSystem()
    {
        return system;
    }
    
}
